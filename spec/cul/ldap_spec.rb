require "spec_helper"

describe Cul::LDAP do
  it "has a version number" do
    expect(Cul::LDAP::VERSION).not_to be nil
  end

  describe '.new' do
    it 'creates a new connection' do
      connection = subject.connection
      expect(connection).not_to be nil
      expect(connection.class).to be Net::LDAP
      expect(connection.host).to eql 'ldap.columbia.edu'
      expect(connection.port).to eql "389"
    end
  end

  describe '#find_by_uni' do
    include_context 'ldap entries'

    before :each do
      connection = double("connection")
      allow(connection).to receive(:search).with(search_params).and_return(ldap_entries)
      allow_any_instance_of(Cul::LDAP).to receive(:build_connection).and_return(connection)
    end

    let(:search_params) do
      { :base => "o=Columbia University, c=US", :filter => Net::LDAP::Filter.eq("uid", uni) }
    end

    it 'makes correct query' do
      expect(subject.connection).to receive(:search).with(search_params)
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
