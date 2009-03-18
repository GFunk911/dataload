# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dataload}
  s.version = "0.8.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Harris"]
  s.date = %q{2009-03-18}
  s.email = %q{GFunk913@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["lib/dataload/batch_insert.rb", "lib/dataload/column.rb", "lib/dataload/dsl/master_loader_dsl.rb", "lib/dataload/dsl/table_loader_dsl.rb", "lib/dataload/ext/active_record.rb", "lib/dataload/ext/enumerator.rb", "lib/dataload/ext/faster_csv.rb", "lib/dataload/master_loader.rb", "lib/dataload/migration.rb", "lib/dataload/table_loader.rb", "lib/dataload/table_manager.rb", "lib/dataload/table_module.rb", "lib/dataload.rb", "samples/sample.rb", "samples/tables.rb", "spec/dataload_spec.rb", "spec/spec_helper.rb", "LICENSE", "README.rdoc", "VERSION.yml"]
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
