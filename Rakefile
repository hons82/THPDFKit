desc 'Run tests'
task :test do
  command = "xcodebuild \
    -workspace THPDFKit.xcworkspace \
    -scheme THPDFKitDemo \
    -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' \
    test"
  system(command) or exit 1
end

task :default => :test
