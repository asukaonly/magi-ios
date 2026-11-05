#!/usr/bin/env ruby
# Run only when changing project membership. The generated project is committed.
require 'xcodeproj'
root = File.expand_path('..', __dir__)
Dir.chdir(root)
project = Xcodeproj::Project.new('MagiIOS.xcodeproj')
project.root_object.attributes['LastUpgradeCheck'] = '2600'
project.root_object.development_region = 'en'
project.root_object.known_regions = ['en', 'zh-Hans', 'Base']
app = project.new_target(:application, 'MagiIOS', :ios, '17.0')
app_group = project.main_group.new_group('MagiIOS', 'MagiIOS')
Dir.glob('MagiIOS/*.swift').sort.each { |path| app.add_file_references([app_group.new_file(File.basename(path))]) }
app_group.new_file('Info.plist')
app_group.new_file('MagiIOS.entitlements')
resources = app_group.new_group('Resources', 'Resources')
['Assets.xcassets', 'PrivacyInfo.xcprivacy'].each { |file| app.resources_build_phase.add_file_reference(resources.new_file(file)) }
['Localizable.strings', 'InfoPlist.strings'].each do |name|
  group = resources.new_variant_group(name)
  ['en', 'zh-Hans'].each do |lang|
    ref = group.new_file("#{lang}.lproj/#{name}")
    ref.name = lang
  end
  app.resources_build_phase.add_file_reference(group)
end
package = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package.relative_path = 'Packages/MagiCore'
project.root_object.package_references << package
product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product.package = package
product.product_name = 'MagiCore'
app.package_product_dependencies << product
build = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build.product_ref = product
app.frameworks_build_phase.files << build
ui = project.new_target(:ui_test_bundle, 'MagiIOSUITests', :ios, '17.0')
ui.add_dependency(app)
ui_group = project.main_group.new_group('MagiIOSUITests', 'MagiIOSUITests')
Dir.glob('MagiIOSUITests/*.swift').sort.each { |path| ui.add_file_references([ui_group.new_file(File.basename(path))]) }
[app, ui].each do |target|
  target.build_configurations.each do |config|
    settings = config.build_settings
    settings['SWIFT_VERSION'] = '6.0'
    settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    settings['CODE_SIGN_STYLE'] = 'Automatic'
    settings['PRODUCT_BUNDLE_IDENTIFIER'] = target == app ? 'com.asuka.magi.ios' : 'com.asuka.magi.ios.uitests'
    settings['CURRENT_PROJECT_VERSION'] = '1'
    settings['MARKETING_VERSION'] = '0.1.0'
    settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'YES'
    if target == app
      settings['INFOPLIST_FILE'] = 'MagiIOS/Info.plist'
      settings['CODE_SIGN_ENTITLEMENTS'] = 'MagiIOS/MagiIOS.entitlements'
      settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
      settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
    else
      settings['GENERATE_INFOPLIST_FILE'] = 'YES'
      settings['TEST_TARGET_NAME'] = 'MagiIOS'
    end
  end
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_build_target(ui, false)
scheme.add_test_target(ui)
scheme.set_launch_target(app)
scheme.save_as(project.path, 'MagiIOS', true)
puts 'Generated MagiIOS.xcodeproj'
