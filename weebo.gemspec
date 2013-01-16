# encoding: utf-8

Gem::Specification.new do |s|
  s.name    = 'weebo'
  s.version = '0.0.1'
  
  s.summary = 'Define Google Analytics Content Experiments with ease.'
  s.description = 'Here be a description.'
  
  s.authors  = ['Clemens Kofler']
  s.email    = 'clemens@railway.at'
  s.homepage = 'https://github.com/clemens/weebo'
  
  s.files = Dir['Rakefile', '{bin,lib,test,spec}/**/*', 'README*', 'LICENSE*']

  s.add_dependency 'actionpack'
  s.add_dependency 'routing-filter', '>= 0.3.1'
end
