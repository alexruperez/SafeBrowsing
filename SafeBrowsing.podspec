Pod::Spec.new do |s|
  s.name             = 'SafeBrowsing'
  s.version          = '0.1.2'
  s.summary          = 'Protect your users against malware and phishing threats using Google Safe Browsing'

  s.homepage         = 'https://github.com/alexruperez/SafeBrowsing'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Alex Rupérez' => 'contact@alexruperez.com' }
  s.source           = { :git => 'https://github.com/alexruperez/SafeBrowsing.git', :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/alexruperez"

  s.ios.deployment_target = '10.0'

  s.source_files     ="SafeBrowsing/*.{h,swift}"
end
