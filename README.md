# USE THIS

## HOW TO USE
### Create laravel product
```bash
docker run --rm --interactive --tty -v $(pwd):/app composer:2.0.8 bash -c "composer create-project --prefer-dist laravel/laravel ."
```

### Clone docker modules
```bash
git submodule add -b laravel-lamp https://github.com/cazuu/docker-template.git docker
git submodule update -i
```

### Update submodule
```bash
git submodule update -i --remote --recursive
```

## Change IP and Port
1. Copy the .env.example .env.
2. Change the IP and Port of .env to any value
3. Restart the container
