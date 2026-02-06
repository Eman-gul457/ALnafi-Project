use admin
db.createUser({
  user: "openedx",
  pwd: "CHANGE_ME",
  roles: [
    { role: "readWrite", db: "openedx" },
    { role: "dbAdmin", db: "openedx" }
  ]
})

rs.initiate({_id: "rs0", members: [{_id: 0, host: "127.0.0.1:27017"}]})
