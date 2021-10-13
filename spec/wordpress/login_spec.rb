require_relative '../spec_helper'

describe Wpxf::WordPress::Login do
  let(:subject) do
    subject = Class.new(Wpxf::Module) do
      include Wpxf::Net::HttpClient
      include Wpxf::WordPress::Options
      include Wpxf::WordPress::Urls
      include Wpxf::WordPress::Login
    end.new

    subject.set_option_value('host', '127.0.0.1')
    subject.set_option_value('target_uri', '/wp/')
    subject
  end

  describe '#wordpress_login_post_body' do
    it 'returns a hash containing the required fields to login to WordPress' do
      body = subject.wordpress_login_post_body('user', 'pass')
      expect(body).to have_key 'log'
      expect(body).to have_key 'pwd'
      expect(body).to have_key 'redirect_to'
      expect(body).to have_key 'wp-submit'

      expect(body['log']).to eq 'user'
      expect(body['pwd']).to eq 'pass'
    end
  end

  describe '#valid_wordpress_cookie?' do
    it 'returns true if a valid WordPress cookie is found' do
      cookies = 'wordpress_test_cookie=WP+Cookie+check; wordpress_a0d5fb633f'\
                'c0ece29d24cfbf8d3d42b4=root%7C1450058494%7CcVPIZ1oLzjjFjA7Fn'\
                'lh5zIySDiHhIkXWMN6vXHydDgd%7Ccc7ee8c368afc26cdef04f73c30e73f'\
                '94d4abc77bfccee9b5e9942cc43424121; wordpress_logged_in_a0d5f'\
                'b633fc0ece29d24cfbf8d3d42b4=root%7C1450058494%7CcVPIZ1oLzjjF'\
                'jA7Fnlh5zIySDiHhIkXWMN6vXHydDgd%7Ce49f1fb7ad2d9f5b3e15d9d302'\
                '20c3b3dc0e02ab6706f13f3d68dfc7ef2d470d'

      expect(subject.valid_wordpress_cookie?(cookies)).to be true
    end
  end

  describe '#wordpress_login' do
    it 'returns the session cookies if a login was successful' do
      res = Wpxf::Net::HttpResponse.new(nil)
      res.code = 200
      res.cookies = {
        'key' => 'value',
        'wordpress_logged_in_a0d5fb633fc0ece29d24cfbf8d3d42b4' =>
          'root%7C1450058494%7CcVPIZ1oLzjjF;'
      }

      allow(subject).to receive(:execute_wp_login_request).and_return(res)
      expect(subject.wordpress_login('root', 'toor')).to eq res.cookies
    end

    it 'returns nil if a login was not successful' do
      res = Wpxf::Net::HttpResponse.new(nil)
      allow(subject).to receive(:execute_wp_login_request).and_return(res)
      expect(subject.wordpress_login('root', 'toor')).to be_nil
    end
  end
end
