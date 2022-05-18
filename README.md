# Ruby for macOS builder

Provide a simple way to build / install [Ruby](https://www.ruby-lang.org/) from source on macOS.

## Prerequisites

- Install `Xcode` / `Command Line Tools` (from `xcode-select --install`)

- Setup environment variables:
```bash
export PATH="/Library/Developer/CommandLineTools/usr/bin:${PATH}"
export CC=clang
export CXX=clang++
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk
```

## Usage

```bash
# Prepare the installation target
sudo mkdir -p /Library/Frameworks/Ruby.framework/Versions
( cd /Library/Frameworks/Ruby.framework && sudo chown :admin Versions && sudo chmod g+w Versions )

# Use the stable release
git clone --depth=1 https://github.com/thachnn/ruby4mac-builder.git
cd ruby4mac-builder

./build.sh --version=2.7.5 --prefix=/Library/Frameworks/Ruby.framework/Versions/2.7 \
  --scratch-path=/usr/local/src --with-openssl=1.1.1n --without-readline --no-tests

# Setup environments
sudo ln -s /Library/Frameworks/Ruby.framework/Versions/2.7/lib/ruby/gems/2.7.0 /Library/Ruby/Gems/
sudo ln -s /Library/Frameworks/Ruby.framework/Versions/2.7/bin/* /usr/local/bin/
```

## Examples

```bash
```
