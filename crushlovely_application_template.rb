run "rm public/index.html"
run "rm -rf log/*"
run "touch .gitignore;"
run "cat > .gitignore << EOF
.DS_Store
database.yml
log/*
tmp/*
public/system/*
EOF"

generate(:controller, "Home index")
route "map.root :controller => 'home'"

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

