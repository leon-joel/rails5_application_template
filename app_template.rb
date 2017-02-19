# coding: utf-8

#
# WARNING: 
#   MinGW環境では動作しそうだが(wgetを別途インストールすれば）、なぜか yes?のあたりで止まってしまう。
#   Windows環境でも正常に動作するよう erb2haml を自前のものに置き換えているので注意。
# 
# USAGE:
#   # PostgreSQL
#   $ rails new test_app --database=postgresql --skip-test --skip-bundle -m my_rails5_app_template.rb
#
# ※Rails4の場合は --skip-test ではなく --skip-test-unit
# ※ActiveRecordを使わない場合は --skip-active-record
#

require 'bundler'

require 'rbconfig'
def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :unknown
    end
  )
end


# 質問 ※MinGW環境では yes? がちゃんと動かない
use_mongodb = yes?('Use MongoDB? [yes or ELSE]')

# メールアドレスの取得
# mail_address = ask("What's your current email address?")

# clean file
# run 'rm README.rdoc'

# .gitignore
# run 'gito -u'   # giboはignore情報をローカルに保持しているので、たまにはそれらを更新してあげた方がいい
run 'gibo Windows macOS Ruby Rails Sass JetBrains SublimeText Vagrant VisualStudioCode > .gitignore' rescue nil
gsub_file '.gitignore', /^config\/initializers\/secret_token.rb$/, ''
gsub_file '.gitignore', /config\/secret.yml/, ''

# Ruby Version
ruby_version = `ruby -v`.scan(/\d\.\d\.\d/).flatten.first
insert_into_file 'Gemfile', <<~EOS, after: "source 'https://rubygems.org'"

  ruby '#{ruby_version}'
EOS
run "echo '#{ruby_version}' > ./.ruby-version"

# add to Gemfile
append_file 'Gemfile', <<~CODE

  # Bootstrap & Bootswatch & font-awesome
  gem 'bootstrap-sass'
  gem 'bootswatch-rails'
  gem 'font-awesome-rails'

  # http://www.mk-mode.com/octopress/2015/01/08/rails-installation-bootstrap-bootswatch/
  gem 'autoprefixer-rails'

  # turbolinks support
  # gem 'jquery-turbolinks'

  # sprocket-rails (3.0.0 is not good...)
  # gem 'sprockets-rails', '2.3.3'

  # See https://raw.githubusercontent.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  # CSS Support
  # gem 'less-rails'

  # App Server
  # gem 'unicorn'

  # Slim
  # gem 'slim-rails'

  # Haml
  gem 'haml-rails'
  group :development do
    # gem 'erb2haml'
    gem 'erb2haml-leon', '>= 0.1.5.7', github: 'leon-joel/erb2haml-leon'
    # gem 'erb2haml-leon', path: '../erb2haml-leon'
  end

  # Assets log cleaner
  # gem 'quiet_assets'

  # Form Builders
  gem 'simple_form'

  # # Process Management
  # gem 'foreman'

  # PG/MySQL Log Formatter
  # gem 'rails-flog'

  # Pagenation
  gem 'kaminari'
  # gem 'kaminari', '~> 0.17' # kaminari1.0からmongodbサポートがなくなるそうなので、0.x に固定しておく。
  # gem 'kaminari-mongoid'  # kaminari1.0にした場合には kaminari-mongoid が必要になるとのこと。
  # group :development, :test do
  #   gem 'mongoid-rspec', github: "chocoken517/mongoid-rspec"
  # end

  # NewRelic
  # gem 'newrelic_rpm'

  # Hash extensions
  # gem 'hashie'

  # Cron Manage
  # gem 'whenever', require: false

  # Presenter Layer Helper
  # gem 'active_decorator'

  # Table(Migration) Comment
  # gem 'migration_comments'

  # Exception Notifier
  # gem 'exception_notification'

  group :development do
    # gem 'html2slim'

    # N+1問題の検出
    # gem 'bullet'

    # Rack Profiler
    # gem 'rack-mini-profiler'

    # Error時の表示を分かりやすく
    gem 'better_errors'
    gem 'binding_of_caller'
  end

  group :development, :test do
    # Pry & extensions
    # gem 'pry-rails'
    # gem 'pry-coolline'
    # gem 'pry-byebug'
    # gem 'rb-readline'

    # PryでのSQLの結果を綺麗に表示
    # gem 'hirb'
    # gem 'hirb-unicode'

    # pryの色付けをしてくれる
    # gem 'awesome_print'

    # Rspec
    gem 'rspec-rails'
    gem 'rails-controller-testing'  # for assigns method ※https://github.com/rails/rails-controller-testing

    # test fixture
    gem 'factory_girl_rails'

    # Deploy
    # gem 'capistrano', '~> 3.2.1'
    # gem 'capistrano-rails'
    # gem 'capistrano-rbenv'
    # gem 'capistrano-bundler'
    # gem 'capistrano3-unicorn'
  end

  group :test do
    # HTTP requests用のモックアップを作ってくれる
    # gem 'webmock'
    # gem 'vcr'

    # Time Mock
    gem 'timecop'

    # テスト用データを生成
    # gem 'faker'

    # テスト環境のテーブルをきれいにする
    # gem 'database_rewinder'
    gem 'database_cleaner'  # テスト実行後にDBをクリア

    gem 'capybara'          # for feature spec
    gem 'launchy'           # Capybaraでテスト中に現在のページをブラウザで開ける

    gem 'poltergeist'       # headless driver
  end

  group :production, :staging do
    # ログ保存先変更、静的アセット Heroku 向けに調整
    # gem 'rails_12factor'  # Rails5から不要になったとのこと
  end
CODE

# MongoDB
# ※kaminari1.0にした場合には kaminari-mongoid が必要になるとのこと。
# ----------------------------------------------------------------
if use_mongodb
  append_file 'Gemfile' do
    <<~CODE

    # Mongoid
    gem 'mongoid'
    gem 'kaminari-mongoid'
    group :development, :test do
      gem 'mongoid-rspec', github: "chocoken517/mongoid-rspec"
    end
    CODE
  end
end

#
# Remote debug
# ※ruby2.3以降で、ruby-debug-ide のインストール（ビルド）時に以下エラーが発生した。
#    Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
#       can't modify frozen String
# ※但し、手動でgem install したら何事もなくインストールできた…（原因不明）
# ----------------------------------------------------------------
if os == :macosx || os == :linux
  append_file 'Gemfile' do
    <<~CODE
      group :development do
        gem 'ruby-debug-ide'
        gem 'debase'
      end
    CODE
  end

  get File.expand_path('../root/run_rdebug', __FILE__), './run_rdebug'
end

#
# bundle install
# ----------------------------------------------------------------
Bundler.with_clean_env do
  # run 'bundle install --path vendor/bundle --jobs=4'
  run 'bundle install --jobs=2'
end

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    # config.active_record.default_timezone = :local

    # 日本語化
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # bootstrap対応で追記 Railstutorial 5.1.2
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    # Viewの呼び出しをログ出力する?
    config.action_view.logger = nil

    # デフォルトのテンプレートエンジン
    config.generators.template_engine = :haml

    # assetsへのアクセスログを抑止するgem "quiet_assets" を使う?
    # config.quiet_assets = false

    # generatorの設定
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end

    # # libファイルの自動読み込み
    # config.autoload_paths += %W(#{config.root}/lib)
    # config.autoload_paths += Dir["#{config.root}/lib/**/"]
  }
end

# For Bullet (N+1 Problem)
# insert_into_file 'config/environments/development.rb',%(
#   # Bulletの設定
#   config.after_initialize do
#     Bullet.enable = true # Bulletプラグインを有効
#     Bullet.alert = true # JavaScriptでの通知
#     Bullet.bullet_logger = true # log/bullet.logへの出力
#     Bullet.console = true # ブラウザのコンソールログに記録
#     Bullet.rails_logger = true # Railsログに出力
#   end
# ), after: 'config.assets.debug = true'

# # Exception Notifier
# insert_into_file 'config/environments/production.rb',%(
#   # Exception Notifier
#   Rails.application.config.middleware.use ExceptionNotification::Rack,
#     :email => {
#       :email_prefix => "[#{@app_name}] ",
#       :sender_address => %{"notifier" <#{mail_address}>},
#       :exception_recipients => %w{#{mail_address}}
#     }
# ), after: 'config.active_record.dump_schema_after_migration = false'

# set Japanese locale
get 'https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml', 'config/locales/ja.yml'

# erb => slim
# Bundler.with_clean_env do
#   run 'bundle exec erb2slim -d app/views'
# end

# erb => haml
# ※windows対応の為、自前で修正したerb2hamlを使用する
Bundler.with_clean_env do
  # run 'bundle exec rake hamlleon:replace_erbs'
  rake "hamlleon:replace_erbs"
end

# Bootstrap/Bootswach/Font-Awesome
remove_file 'app/assets/stylesheets/application.css'
# get 'https://raw.githubusercontent.com/leon-joel/rails5_application_template/master/app/assets/stylesheets/application.css.scss', 'app/assets/stylesheets/application.css.scss'
get File.expand_path('../app/assets/stylesheets/application.css.scss', __FILE__), 'app/assets/stylesheets/application.css.scss'

insert_into_file 'app/assets/javascripts/application.js', <<~EOS.chomp!, after: %r(^//= require jquery$)

  //= require bootstrap-sprockets
  EOS
  

# Simple Form
# generate 'simple_form:install'
generate 'simple_form:install --bootstrap'

# Whenever
# run 'wheneverize .'

# Capistrano
# Bundler.with_clean_env do
#   run 'bundle exec cap install'
# end

# Kaminari config
generate 'kaminari:config'

# Database
# run 'rm -rf config/database.yml'
# if yes?('Use MySQL?([yes] else PostgreSQL)')
#   run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/mysql/database.yml -P config/'
# else
#   run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/postgresql/database.yml -P config/'
#   run "createuser #{@app_name} -s"
# end

Bundler.with_clean_env do
  rake "db:create"
end

# Unicorn(App Server)
# run 'mkdir config/unicorn'
# run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/unicorn/development.rb -P config/unicorn/'
# run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/unicorn/heroku.rb -P config/unicorn/'
# run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/unicorn/production.rb -P config/unicorn/'
# run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/unicorn/staging.rb -P config/unicorn/'
# run "echo 'web: bundle exec unicorn -p $PORT -c ./config/unicorn/heroku.rb' > Procfile"

# Rspec/Guard
# ----------------------------------------------------------------
# Rspec
generate 'rspec:install'

run "echo '--color -f d' > .rspec"

gsub_file 'spec/spec_helper.rb', "require 'rspec/autorun'", ''

insert_into_file 'spec/spec_helper.rb', before: 'RSpec.configure do |config|' do
  <<~EOS
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  require 'factory_girl_rails'
  require 'capybara/poltergeist'

  EOS
end

insert_into_file 'spec/spec_helper.rb', after: 'RSpec.configure do |config|' do
  # mongodbを使用する場合の変数を定義
  if use_mongodb
    mongo_before_suite = <<~EOS
      # memo: https://blog.hello-world.jp.net/ruby/1024/
      DatabaseCleaner[:mongoid].strategy = :truncation
    EOS
    mongo_before_each = <<~EOS
      DatabaseCleaner[:mongoid].clean
      # https://github.com/DatabaseCleaner/database_cleaner
      # DatabaseCleaner[:mongoid].start   # https://blog.hello-world.jp.net/ruby/1024/
    EOS
    mongo_after_each = <<~EOS
      # DatabaseCleaner[:mongoid].clean   # commented out. to be enabled to check data after test failed.
    EOS

  end

  # Windows特有の処理を定義
  if os == :windows
    phantomjs_path_windows = <<~EOS
      # NOTE: need to add phantomjs to PATH
      options = { phantomjs: "phantomjs.exe", timeout: 50 }
    EOS
  end

  # 挿入する文字列本体 ※EOSの後ろに改行を入れておかないと、do |config|の真後ろから挿入される
  <<-"EOS"

  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    #{phantomjs_path_windows}
    Capybara::Poltergeist::Driver.new(app, options)
  end

  config.before(:all) do
    FactoryGirl.reload
  end

  config.before(:suite) do
    # DatabaseCleaner.clean_with(:truncation,{:except => %w{categories jobs initials job_positions}})
    # DatabaseCleaner.strategy = :transaction

    #{mongo_before_suite}
  end

  config.before :each do
    # DatabaseCleaner.start

    #{mongo_before_each}
  end

  config.after :each do
    # DatabaseCleaner.clean

    #{mongo_after_each}
  end

  # config.include FactoryGirl::Syntax::Methods
  EOS
end


if use_mongodb
  generate 'mongoid:config'

  append_file 'config/mongoid.yml', <<~CODE
    # mongoid 5.x
    #
    production:
      clients:
        default:
         # The standard MongoDB connection URI allows for easy
         # replica set connection setup.
         # Use environment variables or a config file to keep your
         # credentials safe e.g. <%= ENV['MONGODB_URI'] %>.
         uri: <%= ENV['MONGODB_URI'] %>

         options:
           # The default timeout is 5, which is the time in seconds
           # for a connection to time out.
           # We recommend 15 because it allows for plenty of time
           # in most operating environments.
           connect_timeout: 15
  CODE

  # insert_into_file 'spec/spec_helper.rb',%(
  #   # Clean/Reset Mongoid DB prior to running each test.
  #   config.before(:each) do
  #     Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  #   end
  # ), after: 'RSpec.configure do |config|'

end


# Redis
# ----------------------------------------------------------------
# use_redis = if yes?('Use Redis? [yes or ELSE]')
# append_file 'Gemfile', <<-CODE
# \n# Redis
# gem 'redis-objects'
# gem 'redis-namespace'
# CODE

# Bundler.with_clean_env do
#   run 'bundle install'
# end

# run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/initializers/redis.rb -P config/initializers/'
# end



# git init
# ----------------------------------------------------------------
git :init
# git :add => '.'
# git :commit => "-a -m 'first commit'"

# heroku deploy
# ----------------------------------------------------------------
# if yes?('Use Heroku? [yes or ELSE]')
#   def heroku(cmd, arguments="")
#     run "heroku #{cmd} #{arguments}"
#   end

#   # herokuに不要なファイルを設定
#   file '.slugignore', <<-EOS.gsub(/^  /, '')
#   *.psd
#   *.pdf
#   test
#   spec
#   features
#   doc
#   docs
#   EOS

#   git :add => '.'
#   git :commit => "-a -m 'Configuration for heroku'"

#   heroku_app_name = @app_name.gsub('_', '-')
#   heroku :create, "#{heroku_app_name}"

#   # config
#   run 'heroku config:add SECRET_KEY_BASE=`rake secret`'
#   run 'heroku config:add TZ=Asia/Tokyo'

#   # addons
#   heroku :'addons:create', 'logentries'
#   heroku :'addons:create', 'scheduler'
#   heroku :'addons:create', 'mongolab' if use_mongodb
#   heroku :'addons:create', 'rediscloud' if use_redis

#   git :push => 'heroku master'
#   heroku :run, "rake db:migrate --app #{heroku_app_name}"

#   # newrelic
#   if yes?('Use newrelic?[yes or ELSE]')
#     heroku :'addons:create', 'newrelic'
#     heroku :'addons:open', 'newrelic'
#     run 'wget https://raw.githubusercontent.com/morizyun/rails4_template/master/config/newrelic.yml -P config/'
#     gsub_file 'config/newrelic.yml', /%APP_NAME/, @app_name
#     key_value = ask('Newrelic licence key value?')
#     gsub_file 'config/newrelic.yml', /%KEY_VALUE/, key_value
#   end
# end
