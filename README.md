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

./build.sh --version=2.7.6 --prefix=/Library/Frameworks/Ruby.framework/Versions/2.7 \
  --scratch-path=/usr/local/src --with-openssl=1.1.1n --without-readline --unit-test

# Setup environments
sudo ln -s /Library/Frameworks/Ruby.framework/Versions/2.7/lib/ruby/gems/2.7.0 /Library/Ruby/Gems/
sudo ln -s /Library/Frameworks/Ruby.framework/Versions/2.7/bin/* /usr/local/bin/
```

## Examples

- Install Ruby 2.7.5 with GDBM and RDoc for `universal` architecture
  (replace `--enable-install-rdoc` with `--with-rdoc=ri,html` if you want to install HTML RDoc)
```bash
./build.sh --prefix=/Library/Frameworks/Ruby.framework/Versions/2.7 \
  --scratch-path=/usr/local/src --with-gdbm=1 --with-universal --extra-opts=--enable-install-rdoc
```

- Build Ruby 2.6.8 as portable package
```bash
./build.sh --version=2.6.8 --prefix=/opt/local --scratch-path=/usr/local/src \
  --with-gdbm=1 --with-universal --enable-rpath --extra-opts=--with-static-linked-ext --unit-test

# Cleanup
find /opt/local/{include,lib/pkgconfig} -depth 1 ! -name '*ruby*' -delete
```
