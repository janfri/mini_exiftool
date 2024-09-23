# -*- encoding: utf-8 -*-
# stub: mini_exiftool 2.11.0 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "mini_exiftool"
  s.version = "2.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2024-03-26"
  s.description = "This library is a wrapper for the ExifTool command-line application\n(https://exiftool.org) written by Phil Harvey.\nIt provides the full power of ExifTool to Ruby: reading and writing of\nEXIF-data, IPTC-data and XMP-data.\n"
  s.email = "janfri26@gmail.com"
  s.files = ["./.aspell.pws", "COPYING", "Changelog", "Gemfile", "README.md", "Rakefile", "Tutorial.md", "examples/copy_icc_profile.rb", "examples/external_photo.rb", "examples/print_portraits.rb", "examples/shift_time.rb", "examples/show_speedup_with_fast_option.rb", "lib/mini_exiftool.rb", "mini_exiftool.gemspec", "regtest/read_all.rb", "regtest/read_all.yml", "test/data", "test/data/Bad_PreviewIFD.jpg", "test/data/Canon.jpg", "test/data/INFORMATION", "test/data/invalid_byte_sequence_in_utf8.json", "test/data/invalid_rational.json", "test/data/test.jpg", "test/data/test.jpg.json", "test/data/test_coordinates.jpg", "test/data/test_encodings.jpg", "test/data/test_special_dates.jpg", "test/helpers_for_test.rb", "test/test_bad_preview_ifd.rb", "test/test_class_methods.rb", "test/test_composite.rb", "test/test_copy_tags_from.rb", "test/test_dumping.rb", "test/test_encodings.rb", "test/test_filename_access.rb", "test/test_from_hash.rb", "test/test_instance_methods.rb", "test/test_invalid_byte_sequence_in_utf8.rb", "test/test_invalid_rational.rb", "test/test_io.rb", "test/test_pstore.rb", "test/test_read.rb", "test/test_read_coordinates.rb", "test/test_read_numerical.rb", "test/test_save.rb", "test/test_special.rb", "test/test_special_dates.rb", "test/test_write.rb"]
  s.homepage = "https://github.com/janfri/mini_exiftool"
  s.licenses = ["LGPL-2.1"]
  s.post_install_message = "+-----------------------------------------------------------------------+\n| Please ensure you have installed exiftool at least version 7.65       |\n| and it's found in your PATH (Try \"exiftool -ver\" on your commandline).|\n| For more details see                                                  |\n| https://exiftool.org/install.html             |\n| You need also Ruby 1.9 or higher.                                     |\n| If you need support for Ruby 1.8 or exiftool prior 7.65 install       |\n| mini_exiftool version < 2.0.0.                                        |\n+-----------------------------------------------------------------------+\n"
  s.rubygems_version = "3.6.0.dev"
  s.summary = "This library is a wrapper for the ExifTool command-line application (https://exiftool.org)."

  s.specification_version = 4

  s.add_dependency(%q<ostruct>, [">= 0.6.0"])
  s.add_dependency(%q<pstore>, [">= 0.1.3"])

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rim>, ["~> 2.17"])
  s.add_development_dependency(%q<test-unit>, [">= 0"])
  s.add_development_dependency(%q<regtest>, ["~> 2"])
end
