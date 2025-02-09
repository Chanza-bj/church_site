alias ChurchSite.Accounts.Admin
alias ChurchSite.Repo

# Create initial admin user
%Admin{}
|> Admin.changeset(%{
  email: "boydbjchanza@gmail.com",
  password: "P@ssw0rd",
  name: "Boyd Chanza",
  role: "admin",
  active: true
})
|> Repo.insert!()
