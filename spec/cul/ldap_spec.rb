require "spec_helper"

describe Cul::LDAP do
  it "has a version number" do
    expect(Cul::LDAP.version).not_to be nil
  end

  describe '.new' do
    let(:auth_options) {
      { username: 'testuser', password: 'notavalidpassword', method: 'simple' }
    }

    context 'when credientials are not provided' do
      it { is_expected.not_to be nil }

      its(:class) { is_expected.to eql Cul::LDAP }
      its(:host)  { is_expected.to eql 'ldap.columbia.edu' }
      its(:port)  { is_expected.to eql "636" }

      it 'does not have auth options' do
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end
    end

    context 'when auth options are provided within Rails' do
      subject { Cul::LDAP.new }

      it 'ignores creds if config empty' do
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return(nil)
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'successfully stores auth options' do
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return({auth: auth_options})
        expect(
          subject.instance_variable_get(:@auth)
        ).to include(username: "testuser", password: "notavalidpassword", method: :simple)
      end
    end

    context 'when auth options are provided by config file' do
      before :each do
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return(nil)
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_file_config).and_return({auth: auth_options})
      end

      it 'successfully stores auth options' do
        expect(
          subject.instance_variable_get(:@auth)
        ).to include(username: "testuser", password: "notavalidpassword", method: :simple)
      end
    end

    context 'when auth options are provided in arguments' do
      it 'allows empty auth params to go through' do
        ldap = Cul::LDAP.new(auth: {})
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'allows nil auth params to go through' do
        ldap = Cul::LDAP.new(auth: nil)
        expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'successfully stores auth options' do
        ldap = Cul::LDAP.new(auth: auth_options)
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
