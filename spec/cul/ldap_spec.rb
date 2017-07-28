require "spec_helper"

describe Cul::LDAP do
  it "has a version number" do
    expect(Cul::LDAP::VERSION).not_to be nil
  end

  describe '.new' do
    let(:credentials) {
      { 'username' => 'testuser', 'password' => 'notavalidpassword' }
    }

    context 'when credientials are not provided' do
      it { is_expected.not_to be nil }

      its(:class) { is_expected.to eql Cul::LDAP }
      its(:host)  { is_expected.to eql 'ldap.columbia.edu' }
      its(:port)  { is_expected.to eql "636" }

      it 'does not have credentials' do
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end
    end

    context 'when credentials are provided within Rails' do
      # before :each do
      #   allow_any_instance_of(Cul::LDAP).to receive(:rails_credentials).and_return(credentials)
      # end

      subject { Cul::LDAP.new }

      it 'ignores creds if config empty' do
        allow_any_instance_of(Cul::LDAP).to receive(:rails_credentials).and_return(nil)
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'successfully stores credentials' do
        allow_any_instance_of(Cul::LDAP).to receive(:rails_credentials).and_return(credentials)
        expect(
          subject.instance_variable_get(:@auth)
        ).to include(username: "testuser", password: "notavalidpassword", method: :simple)
      end
    end

    context 'when credentials are provided by config file' do
      before :each do
        allow_any_instance_of(Cul::LDAP).to receive(:rails_credentials).and_return(nil)
        allow_any_instance_of(Cul::LDAP).to receive(:credentials_from_file).and_return(credentials)
      end

      it 'successfully stores credentials' do
        expect(
          subject.instance_variable_get(:@auth)
        ).to include(username: "testuser", password: "notavalidpassword", method: :simple)
      end
    end

    context 'when credentials are provided in arguments' do
      it 'allows empty auth params to go through' do
        ldap = Cul::LDAP.new(auth: {})
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'allows nil auth params to go through' do
        ldap = Cul::LDAP.new(auth: nil)
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'successfully stores credentials' do
        ldap = Cul::LDAP.new(auth: credentials)
        expect(
          ldap.instance_variable_get(:@auth)
        ).to include(username: "testuser", password: "notavalidpassword", method: :simple)
      end
    end
  end

  describe '#find_by_uni' do
    include_context 'ldap entries'

    before :each do
      allow(subject).to receive(:search).with(search_params).and_return(ldap_entries)
    end

    let(:search_params) do
      { :base => "ou=People,o=Columbia University, c=US", :filter => Net::LDAP::Filter.eq("uid", uni) }
    end

    it 'makes correct query' do
      expect(subject).to receive(:search).with(search_params)
      subject.find_by_uni(uni)
    end

    it 'correctly retrieves entry' do
      lookup = subject.find_by_uni(uni)
      expect(lookup).not_to be nil
      expect(lookup.class).to be Cul::LDAP::Entry
      expect(lookup.uni).to eql uni
    end
  end
end
