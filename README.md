# USE THIS

## HOW TO USE
### Create laravel product
```bash
docker run --rm --interactive --tty -v $(pwd):/app composer:1.8.4 bash -c "composer create-project --prefer-dist laravel/laravel ."
```

### Clone docker modules
```bash
git submodule add -b laravel https://github.com/cazuu/docker-template.git docker
git submodule update -i
```

