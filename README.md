# Kubernetes Recipes (Cookbooks)

Chef recipes for installing Kubernetes on Ubuntu 14 with a single node (master - minion)

# Requirements

- Ubuntu 14
- Git
- User with root access (I'm using root here)
- /bin/bash as login shell
- ChefDK (Installing directions down below)

# Usage
`TODO` - Improve recipe to avoid using root

First, switch to root:
```
sudo su -
```

## ChefDK Installation
Download the ChefDK
```
wget https://packages.chef.io/files/stable/chefdk/1.2.22/ubuntu/14.04/chefdk_1.2.22-1_amd64.deb
```
Install
```
sudo dpkg -i chefdk_1.2.22-1_amd64.deb
```
Environment variables config for Chef
```
source <(chef shell-init bash) && \
echo 'source <(chef shell-init bash)' >> ~/.bash_profile
```

## Recipe installation
Clone repo and cd into folder
```
git clone http://rocarras.uchile.cl:9000/faromero/kubernetes-recipes.git && cd kubernetes-recipes
```

## Run recipe
Finally, run the following command to start with cluster installation
```
chef-client -z -o kubernetes_install
```

## Verify installation
Get a list of installed pods:
```
kubectl get pods
```
It should list at least two services: busybox and kubernetes-bootcamp. Something like:
```
NAME                                  READY     STATUS    RESTARTS   AGE
busybox                               1/1       Running   1          4d
kubernetes-bootcamp-390780338-nbb8l   1/1       Running   1          4d
```
Probably in your case those pods could be in a "Container Creating" status. It means that Kubernetes is still installing, maybe downloading docker images of those services. Wait a few seconds and try to get a list of the pods again.

## Contributing

1. Fork it!
2. Create your feature branch: git checkout -b my-new-feature
3. Commit your changes: git commit -am 'Add some feature'
4. Push to the branch: git push origin my-new-feature
5. Submit a pull request :D

## License

The MIT License (MIT)

Copyright (c) 2017 Fabián Romero

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
