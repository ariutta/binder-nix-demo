{ lib
, buildPythonPackage
, fetchPypi
, python
, jupyterlab
, jupyter_packaging
, setuptools
#, distutils
, wheel
, nodejs
, nodePackages
}:

# TODO: the standard setuptools build/install process fails.
# This Nix definition as written does get the prebuilt labextension, but it
# does not use the standard setuptools build/install. Is it OK?
#
# Which dependencies are actually needed? They are haphazardly defined here.

buildPythonPackage rec {
  pname = "jupyterlab_vim";
  version = "0.13.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1frhk6k3f7xjw66bdr6zfxz1m3a1zfv8s192v2gq7v6g21p53kp6";
  };

  nativeBuildInput = [ setuptools wheel nodePackages.typescript ];
  buildInputs = [ jupyter_packaging ];
  propagatedBuildInputs = [ jupyterlab nodejs ];

  doCheck = false;

  format = "other";

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/lib/python3.8/site-packages"
    cp -r ./jupyterlab_vim "$out/lib/python3.8/site-packages/jupyterlab_vim"

    mkdir -p "$out/share/jupyter/labextensions/@axlair"
    cp -r ./jupyterlab_vim/labextension "$out/share/jupyter/labextensions/@axlair/jupyterlab_vim"
    cp ./install.json "$out/share/jupyter/labextensions/@axlair/jupyterlab_vim/install.json"

    runHook postBuild
  '';

  installPhase = ''
    echo "installPhase"
  '';

#  preBuild = ''
#    echo "preBuild"
#    ls -lah ./
#    echo "$out"
#    pwd
#    #exit 1
#    #ls -lah $out
#
#    mkdir $out
#
#    PATH="${jupyterlab}/bin:$PATH"
#    PATH="${nodejs}/bin:$PATH"
#    PATH="${nodePackages.typescript}/bin:$PATH"
#
#    rm tsconfig.json
#    #tsc --lib 'ES5,ES2015,ES2016,ES2017,ES2018,ESNext,DOM,ES6,DOM.Iterable,ScriptHost' --skipLibCheck --suppressExcessPropertyErrors --suppressImplicitAnyIndexErrors --noStrictGenericChecks ./src/*.ts
#    tsc --lib ES2015 --suppressExcessPropertyErrors --suppressImplicitAnyIndexErrors --noStrictGenericChecks ./src/*.ts
#    #tsc --suppressImplicitAnyIndexErrors ./src/*.ts
#    #"jlpm run build:lib && jlpm run build:labextension"
#    #jlpm run 'build:prod'
#    ls -lah ./
#    exit 1
#
#    cp -r ./ $out/
#
#    ${python.interpreter} setup.py bdist_wheel
#
#    #${python.interpreter} setup.py install_data --install-dir=$out --root=$out
#    #sed -i '/ = data\_files/d' setup.py
#  '';

#  pipBuildHook = ''
#    echo "pipBuildHook"
#    ls -lah ./
#    echo "$out"
#    exit 1
#  '';

#  postBuild = ''
#    echo "postBuild"
#    ls -lah ./
#    ls -lah $out
#    exit 1
#  '';

  preInstall = ''
    echo "preInstall"
    ls -lah ./
    ls -lah $out
    #exit 1
  '';

  meta = with lib; {
    description = "Code cell vim bindings.";
    longDescription = "Disclaimer: fork of https://github.com/jwkvam/jupyterlab-vim for personal use. Use at your own risk. The previous one doesn't appear to be active any more, but this one is.";
    homepage = "https://pypi.org/project/jupyterlab-vim/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
