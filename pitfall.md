# 坑点: 不反复发作即可

## compile error

### Plugin "@typescript-eslint" was conflicted between ".eslintrc.json » eslint-config-react-app#overrides[0]" and ".eslintrc.json » @excalidraw/eslint-config".
解决方法, .eslintrc.json中去掉 extends `"@excalidraw/eslint-config"`

### build docker fail `"react-app" to extend from.`
build fail message:
```
Failed to load config "react-app" to extend from.
Referenced from: /opt/node_app/.eslintrc.json
```

try fix 1:
```
npm install -D eslint-config-react-app
```
fail!!

try Dec/25
and fixed temp : use yarn in docker file.

Update Dec/26: yarn一样有问题, 所以不是yarn的问题
- try Dec/26: `RUN npm ci --ignore-scripts` => `RUN npm ci`
- 结果失败

目前的解决方案: 问题只出现在docker build的时候, 所以 `build:app:docker` 不检查eslint `DISABLE_ESLINT_PLUGIN=true`.
```
    "build:app:docker": "DISABLE_ESLINT_PLUGIN=true NODE_ENV=production REACT_APP_DISABLE_SENTRY=true react-scripts build",
```

### build docker fail: for `xxx.d.ts` fail to found
fix: @types从Dev中放到depends中, 特别是lodash.x 部分