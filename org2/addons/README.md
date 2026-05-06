# addons
After cluster has been setup, set the kubeconfig in cli and modify the kubeContext in helmfile appopriately. 

# Deployment
- install helmfile
- adjust values in helmfile if necessary
- run command 
``` bash 
helmfile sync
```

This will deploy all realeases, some releases may not be necessare for example argocd repo credentials if argocd is not to be installed.
Individual releases can be installed explicity with helmfile release selectors in cli

# TODO
- Make kubecontext dynamic
