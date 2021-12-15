# 坑点: 不反复发作即可

## compile error

### Plugin "@typescript-eslint" was conflicted between ".eslintrc.json » eslint-config-react-app#overrides[0]" and ".eslintrc.json » @excalidraw/eslint-config".
解决方法, .eslintrc.json中去掉 extends `"@excalidraw/eslint-config"`
