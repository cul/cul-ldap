shared_context 'ldap entries' do
  let(:uni) { 'abc123' }

  let(:ldap_entry) do
    Net::LDAP::Entry.from_single_ldif_string(
%Q{dn: uni=#{uni},ou=People,o=Columbia University,c=US
departmentNumber: 2206202
campusphone: MS 1-0000
sn: Doe
ou: Columbia University Libraries
mail: janedoe@columbia.edu
uid: #{uni}
givenName: Jane
uni: #{uni}
postalAddress: 201 IAB$Mail Code: 3301$United States
cn: Jane Doe
telephoneNumber: +1 212 851 2903
title: Librarian
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: cuPerson
objectClass: cuRestricted
objectClass: eduPerson}
      )
  end

  let(:ldap_entry_without_mail) do
    Net::LDAP::Entry.from_single_ldif_string(
%Q{dn: uni=#{uni},ou=People,o=Columbia University,c=US
departmentNumber: 2206202
campusphone: MS 1-0000
sn: Doe
ou: Columbia University Libraries
uid: #{uni}
givenName: Jane
uni: #{uni}
postalAddress: 201 IAB$Mail Code: 3301$United States
cn: Jane Doe
telephoneNumber: +1 212 851 2903
title: Librarian
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: cuPerson
objectClass: cuRestricted
objectClass: eduPerson}
      )
  end

  let(:ldap_entries) {
    [Cul::LDAP::Entry.new(ldap_entry)]
  }
end
