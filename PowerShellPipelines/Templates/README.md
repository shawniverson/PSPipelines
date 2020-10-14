# ========= Azure DevOps ========= PowerShell ========= Pipelines =========

## ARM Template for generating a target environment

Populate the parameters.json with appropriate values.

When adding a Personall Access Token 'patToken', a user with Organization level *Project Collection Administrators* will need to generate the PAT and grant *Agent Pools* Read & manage and *Deployment Groups* Read & manage scopes.

Supply DevOpsDGTest DevOpsDGProd Deployment Groups that as defined in your DevOps project. If they do not exist, create them.

Note:  Do not share your customized parameters.json file and do not publish sensitive values in a repository.