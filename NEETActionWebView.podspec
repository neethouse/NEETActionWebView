Pod::Spec.new do |s|
  s.name         = "NEETActionWebView"
  s.version      = "1.0.0"
  s.summary      = "The subclass of UIWebView that can hook a long press links action."
  s.homepage     = "https://github.com/neethouse/NEETActionWebView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "mtmta" => "mtmta@501dev.org" }
  s.source       = { :git => "https://github.com/neethouse/NEETActionWebView.git", :tag => "1.0.0" }
  s.source_files = 'NEETActionWebView/**/*.{h,m}'
  s.public_header_files = 'NEETActionWebView/**/*.h'
  s.platform     = :ios, "6.1"
  s.requires_arc = true
end
