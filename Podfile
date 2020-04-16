source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

use_frameworks!

# Функция, которая содержит все зависимости
def elo_pods
  # Layouts and views
  pod 'PureLayout', '~> 3.1.5'
  pod 'Texture', '~> 2.8.1'

  # Networking
  pod 'RxAlamofire','~> 5.1.0'
  pod "CentrifugeiOS", :git => 'https://github.com/youla-dev/centrifuge-ios.git'
  pod 'MessageKit', '3.0.0'

  # Data
  pod 'SwiftyUserDefaults', '4.0.0'

  # UI
  pod 'PKHUD', '~> 5.3.0'
  pod 'PMSuperButton', '~> 3.0.2'
  pod 'InputMask', '~> 4.3.0'
  pod "CBPinEntryView", '~> 1.7.1'
  pod 'BEMCheckBox', '~> 1.4.1'
  pod 'FloatingPanel', '~> 1.7.1'
  pod 'SDWebImage', '~> 5.3.2'

  # DI
  pod 'Swinject', '~> 2.7.1'

  # Extensions
  pod 'Closures', '~> 0.7'

  # Keyboard Manager
  pod 'IQKeyboardManagerSwift', '~> 6.5.4'

  pod 'GoogleMaps', '~> 3.6.0'

  # Realm
  pod 'RealmSwift', '3.21.0'
end

# Для каждого таргета
target 'EtuDelivery' do
  elo_pods
end
