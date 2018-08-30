platform :osx, "10.7"
workspace 'Gureum'
xcodeproj 'Gureum.xcodeproj'

pod 'cdebug'
pod 'FoundationExtension'

target :'OSX' do
    xcodeproj 'Gureum.xcodeproj'
end

target :'App' do
    platform :ios, "8.0"
    xcodeproj 'iOS.xcodeproj'
    pod 'FoundationExtension/UIKitExtension'
    pod 'Fabric'
    pod 'Crashlytics'
end
target :'iOS' do
    platform :ios, "8.0"
    xcodeproj 'iOS.xcodeproj'
    pod 'FoundationExtension/UIKitExtension'
    pod 'Fabric'
    pod 'Crashlytics'
end