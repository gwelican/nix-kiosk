{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ha-health-exporter";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ python3Packages.setuptools ];
  buildInputs = [ python3Packages.python ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ha-health-exporter.py $out/bin/ha-health-exporter
    runHook postInstall
  '';

  meta = with lib; {
    description = "HomeAssistant API health exporter for Prometheus";
    homepage = "https://www.home-assistant.io/";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
})
