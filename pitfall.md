# 坑点: 不反复发作即可

## compile error

### Plugin "@typescript-eslint" was conflicted between ".eslintrc.json » eslint-config-react-app#overrides[0]" and ".eslintrc.json » @excalidraw/eslint-config".
解决方法, .eslintrc.json中去掉 extends `"@excalidraw/eslint-config"`

### build docker fail
```
Failed to load config "react-app" to extend from.
Referenced from: /opt/node_app/.eslintrc.json
```

try fix 1:
```
npm install -D eslint-config-react-app
```
fail!!1

finally fixed : use yarn in docker file.
