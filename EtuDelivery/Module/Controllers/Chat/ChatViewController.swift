//
// Created by Евгений Доленко on 30.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import UIKit
import CentrifugeiOS
import MessageKit
import RxSwift
import InputBarAccessoryView
import IQKeyboardManagerSwift
import SDWebImage

class ChatViewController: MessagesViewController {
    let disposeBag = DisposeBag()
    let hudProvider = UIApplication.container.resolve(HudProviderProtocol.self)!

    var client: CentrifugeClient? = nil
    var model: ChatModel!

    let chatService = ChatService()
    let attachHandler = AttachmentHandler()

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false

        configureMessageCollectionView()
        configureMessageInputBar()
        self.attachHandler.delegate = self

        navigationItem.title = "chat".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized(), style: .plain) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        IQKeyboardManager.shared.enable = false
        loadMessages()
        connectSocket()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    func connectSocket() {
        let timestamp = AppDelegate.model.auth.timestamp
        let cToken = AppDelegate.model.auth.token
        let userId = AppDelegate.model.auth.uid

        let creds = CentrifugeCredentials(token: cToken, user: String(userId), timestamp: String(timestamp))
        let url = Constants.CENTRIFUGO_ADDRESS
        client = Centrifuge.client(url: url, creds: creds, delegate: self)

        client?.connect { [weak self] message, error in
            if message != nil {
                self?.subscribeToChannel()
            }
        }
    }

    func subscribeToChannel() {
        client?.subscribe(toChannel: Constants.CHAT_CHANNEL, delegate: self) { message, error in

        }
    }

    @objc func loadMessages() {
        self.refreshControl.beginRefreshing()
        let disposable = chatService
                .getChatMessages(orderId: model.orderId)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.model.messages = response
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToBottom()

                    self?.refreshControl.endRefreshing()
                }, onError: { [weak self] error in
                    self?.refreshControl.endRefreshing()
                    print(error)
                })

        disposeBag.insert(disposable)
    }

    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true

        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMessages), for: .valueChanged)

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }
    }

    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .mainColor
        messageInputBar.sendButton.setTitleColor(.mainColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
                UIColor.mainColor.withAlphaComponent(0.3),
                for: .highlighted
        )

        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .mainColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        messageInputBar.sendButton.title = "send".localized()
        let size = messageInputBar.sendButton.sizeThatFits(CGSize())
        messageInputBar.sendButton.setSize(CGSize(width: size.width + 5, height: 36), animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: size.width + 5, animated: false)

        messageInputBar.sendButton.title = "send".localized()
        messageInputBar.inputTextView.placeholder = "input_message".localized()

        configureInputBarItems()
    }

    private func configureInputBarItems() {
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.leftStackView.alignment = .center

        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(named: "attach")
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { [weak self] _ in
            self?.onAttachButtonClick()
        }

        let leftItems = [attachButton]
        messageInputBar.setStackViewItems(leftItems, forStack: .left, animated: false)
    }

    func insertMessage(_ message: Message) {
        model.messages.append(message)

        if isLastSectionVisible() {
            messagesCollectionView.reloadData { [weak self] in
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        } else {
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }

    private func onAttachButtonClick() {
        self.attachHandler.showPhotoAttachmentActionSheet(vc: self, source: view)
    }

    private func isLastSectionVisible() -> Bool {
        guard !model.messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: model.messages.count - 1, section: 0)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

extension ChatViewController: CentrifugeClientDelegate, CentrifugeChannelDelegate, MessageCellDelegate {
    func client(_ client: CentrifugeClient, didReceiveRefreshMessage message: CentrifugeServerMessage) {

    }

    func client(_ client: CentrifugeClient, didDisconnectWithError error: Error) {
        loadMessages()
        connectSocket()
    }

    func client(_ client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage) {
        if let messageJson = message.body?["data"] as? [String: Any] {
            if let message = Message(map: messageJson) {
                if (message.orderID == String(model.orderId)) {
                    insertMessage(message)
                }
            }
        }
    }

    func client(_ client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage) {

    }

    func client(_ client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage) {

    }

    func client(_ client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage) {

    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let messageText = messageInputBar.inputTextView.text ?? ""

        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "sending".localized()

        let disposable = chatService
                .sendMessage(orderId: model.orderId, managerId: model.managerId, message: messageText, attach: nil, attachExt: nil)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self]  response in
                    self?.messageInputBar.inputTextView.placeholder = "input_message".localized()
                    self?.messageInputBar.sendButton.stopAnimating()
                }, onError: { [weak self] error in
                    self?.messageInputBar.inputTextView.placeholder = "input_message".localized()
                    self?.messageInputBar.sendButton.stopAnimating()
                })

        disposeBag.insert(disposable)
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    public func currentSender() -> SenderType {
        return Sender(senderId: String(AppDelegate.model.auth.uid), displayName: AppDelegate.model.auth.name)
    }

    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return model.messages[indexPath.row]
    }

    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }

    public func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return model.messages.count
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    public func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(_):
            if let msg = message as? Message {
                let imageUrl = msg.imageUrl
                imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
            }
        @unknown default:
            return
        }
    }
}

extension ChatViewController: AttachmentDelegate {
    func imagePicked(_ data: Data, _ image: UIImage) {
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "sending".localized()

        chatService.sendImageMessage(orderId: model.orderId, managerId: model.managerId, image: data) { [weak self] in
            self?.messageInputBar.inputTextView.placeholder = "input_message".localized()
            self?.messageInputBar.sendButton.stopAnimating()
        }
    }

    func filePicked(_ fileURL: URL) {}
}

extension ChatViewController {
    func showInfo(message: String, completion: (() -> Void)?) {
        hudProvider.showInfo(message: message, completion: completion)
    }

    func showProgress() {
        hudProvider.showProgress()
    }

    func hideProgress() {
        hudProvider.hideProgress()
    }

    func showSuccess(message: String?, completion: (() -> Void)?) {
        hudProvider.showSuccess(message: message, completion: completion)
    }

    func showSuccess() {
        hudProvider.showSuccess(message: "successfully".localized(), completion: nil)
    }

    func showError(message: String?, completion: (() -> Void)?) {
        hudProvider.showError(message: message, completion: completion)
    }
}