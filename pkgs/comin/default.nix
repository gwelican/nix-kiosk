{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "comin";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "avito-tech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1N0dI0Vd2Q9Jl5JW8VzL8d9mZb5KqZ7b5Qz7b5Qz7bX";
  };

  cargoHash = "sha256-1N0dI0Vd2Q9Jl5JW8VzL8d9mZb5KqZ7b5Qz7b5Qz7bX";

  meta = with lib; {
    description = "GitOps pull-based provisioning tool";
    homepage = "https://github.com/avito-tech/comin";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
