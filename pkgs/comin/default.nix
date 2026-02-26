{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "comin";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "avito-tech";
    repo = "comin";
    rev = "v${version}";
    hash = "sha256-6L2nI0Vd2Q9Jl5JW8VzL8d9mZb5KqZ7b5Qz7b5Qz7b=";
  };

  cargoHash = "sha256-8L2nI0Vd2Q9Jl5JW8VzL8d9mZb5KqZ7b5Qz7b5Qz7b=";

  meta = with lib; {
    description = "GitOps pull-based provisioning tool";
    homepage = "https://github.com/avito-tech/comin";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
