require "spec_helper"

describe Cul::LDAP do
  it "has a version number" do
    expect(Cul::LDAP.version).not_to be nil
  end

  let(:auth_options) {
    { username: 'testuser', password: 'notavalidpassword', method: 'simple' }
  }
  let(:test_config) {
    { host: 'test.ldap.com', port: 636 , auth: auth_options }
  }
  let(:subject) { Cul::LDAP.new(test_config) }
  let(:empty_subject) { Cul::LDAP.new }


  describe '.new' do
    context 'when credientials are not provided' do
      it 'raises an invalid option error' do
        expect{ empty_subject }.to raise_error(InvalidOptionError, "Missing required cul-ldap configuration option: host")
      end
    end

    context 'when auth options are provided within Rails' do
      it 'raises invalid option error if options hash is empty' do
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return({})
        expect{ empty_subject }.to raise_error()
        # expect(subject.instance_variable_get(:@auth)).to eql Net::LDAP::DefaultAuth
      end

      it 'successfully stores auth options' do
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return(test_config)
        expect( 
          empty_subject.instance_variable_get(:@auth)
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
      before do
        partial_options = { host: 'test.ldap.com', port: 636 } # Everything except :auth hash
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_rails_config).and_return(nil)
        allow_any_instance_of(Cul::LDAP).to receive(:options_from_file_config).and_return(partial_options)
      end

      it 'raises an InvalidOptionError if auth hash not provided' do
        expect{ empty_subject }.to raise_error(InvalidOptionError)
      end

      it 'raises an InvalidOptionError if auth hash has missing values' do
        expect{ Cul::LDAP.new(auth: { username: 'notenough' }) }.to raise_error(InvalidOptionError)
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

  describe '#check_operation_result' do
    it 'raises a NoAuthError if the response has code 50 (Insufficient Access Rights)' do
      allow_any_instance_of(Cul::LDAP).to receive(:get_operation_result).and_return OpenStruct.new( code: 50 )
      expect{ subject.check_operation_result }.to raise_error(NoAuthError)
    end
  end
end
