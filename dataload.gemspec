# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dataload}
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Harris"]
  s.date = %q{2009-03-12}
  s.email = %q{GFunk913@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["lib/dataload/loader.rb", "lib/dataload/sample.rb", "lib/dataload.rb", "spec/dataload_spec.rb", "spec/spec_helper.rb", "LICENSE", "README.rdoc", "VERSION.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/GFunk911/dataload}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_runtime_dependency(%q<GFunk911-mharris_ext>, [">= 0"])
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<GFunk911-mharris_ext>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<GFunk911-mharris_ext>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
  end
end
