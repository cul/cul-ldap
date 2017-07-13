require 'spec_helper'

describe 'Cul::LDAP::Entry' do
  describe '.new' do
    include_context 'ldap entries'

    subject { Cul::LDAP::Entry.new(ldap_entry) }
    its(:name)       { is_expected.to eql 'Jane Doe' }
    its(:email)      { is_expected.to eql 'janedoe@columbia.edu' }
    its(:first_name) { is_expected.to eql 'Jane'}
    its(:last_name)  { is_expected.to eql 'Doe'}
    its(:uni)        { is_expected.to eql 'abc123'}
    its(:title)      { is_expected.to eql 'Librarian'}
    its(:organizational_unit) { is_expected.to eql 'Columbia University Libraries'}

  end
end
