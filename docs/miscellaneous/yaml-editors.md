# Editors for Pipeline and Task yml's

As the size of pipelines grow, it becomes very hard to edit yml's. Moreover, indentation and missed parameters causes error when pipeline line is set/executed. You can use [`validate-pipeline`](https://concourse-ci.org/setting-pipelines.html#fly-validate-pipeline.html) to verify but it would be better if we can have editors highlighing the error much before in development. This would be similar to IDE's highlighing syntax errors. This section will list editors you can use to edit yml's for concourse pipleines and tasks. 

## Visual Studio Code
---------------------
![vscode](/images/vscode-concourse.png)

You can use Visual Studio code, which is free to download [`here`](https://code.visualstudio.com/download) to edit the pipeline and task yml's. Once downloaded, you can install Concourse CI Pipeline Editor [`here`](https://marketplace.visualstudio.com/items?itemName=Pivotal.vscode-concourse). Provides validation and content assist for Concourse CI pipeline and task configuration yml files. This also auto suggests parameters and syntax errors. 

### Functionality
Some of the functionality include:
#### Validation
As you type the text is parsed and checked for basic syntactic and structural correctness. Hover over an error marker to see an explanation

#### Content assist
Having trouble remembering all the names of the attributes, and their spelling? Or can't remember which resource properties to set in the get task params versus its source attributes? Or don't remember what 'special' values are acceptable for a certain property? Content assist to the rescue
#### Documentation Hovers
Having trouble remembering exactly what the meaning of each attribute is? Hover over an attribute and read its detailed documentation

You can find more info and limitations in the plugin page [`here`](https://marketplace.visualstudio.com/items?itemName=Pivotal.vscode-concourse)
## Atom
---------------------
![atom](/images/atom-concourse.gif)

You can use Atom, which is free to download [`here`](https://atom.io) to edit the pipeline and task yml's. Once downloaded, you can install concourse-vis [`here`](https://atom.io/packages/concourse-vis). This is a plugin to preview Concourse pipelines in Atom. One additional advantage with Atom is that it provides concourse pipeline preview before using `set-pipeline`, which is very cool.

You can find more info and limitations in the plugin page [`here`](https://atom.io/packages/concourse-vis)
