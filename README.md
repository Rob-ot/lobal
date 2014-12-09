# lobal

You have lots of projects on your computer. Some require different versions of global npm modules.

Sick of typing ./node_modules/.bin/gulp to use the local gulp binary?

lobal to the rescue!

```bash
# install lobal
$ npm install -g lobal

# add a shim
$ lobal add coffee

# lobal uses the locally installed coffee binary
$ cd ~/project1
~/project1$ npm install coffee-script@1.7.0
~/project1$ coffee -v
CoffeeScript version 1.7.0
~/project1$ cd ../project2
~/project2$ npm install coffee-script@1.8.0
~/project2$ coffee -v
CoffeeScript version 1.8.0

# lobal will also use the globally installed module if you arent in a project directory
~/project2$ npm install -g coffee-script@1.6.0
~/project2$ cd ~
$ coffee -v
CoffeeScript version 1.6.0
```

## API

#### lobal add `module`

Add a shim named `module`

#### lobal remove `module`

Remove a shim named `module`

#### lobal exec `module`

Look for the `module` binary locally or globally and execute the file.


## How it works

The first time you add a shim local will create a .lobal_shims folder in your home folder and add that folder to your PATH by modifying your .bashrc, .bash_profile, or .profile file.

Shims are just tiny shell scripts that are added to the .lobal_shims folder. The shim scripts just run `lobal exec` passing your module name, ex: `lobal exec coffee`.

lobal exec then finds your current project based on your cwd and looks for the specified module there. If the module isn't found in the current project lobal checks to see if the module is installed globally. Once it has found a module lobal executes the file using child_process.spawn with stdio set to 'inherit'.
