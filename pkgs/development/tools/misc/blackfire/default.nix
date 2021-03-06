{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, writeShellScript
, curl
, jq
, common-updater-scripts
}:

stdenv.mkDerivation rec {
  pname = "blackfire-agent";
  version = "1.44.2";

  src = fetchurl {
    url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-agent_${version}_amd64.deb";
    sha256 = "1bam4sb0yhxciykph7wn41zs8fa7c9iwnbihd5kza0cylbb7fbkb";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src $out
    mv $out/usr/* $out
    rmdir $out/usr

    runHook postInstall
  '';

  passthru = {
    updateScript = writeShellScript "update-${pname}" ''
      export PATH="${lib.makeBinPath [ curl jq common-updater-scripts ]}"
      update-source-version "$UPDATE_NIX_ATTR_PATH" "$(curl https://blackfire.io/api/v1/releases | jq .agent --raw-output)"
    '';
  };

  meta = with lib; {
    description = "Blackfire Profiler agent and client";
    homepage = "https://blackfire.io/";
    license = licenses.unfree;
    maintainers = with maintainers; [ jtojnar ];
    platforms = [ "x86_64-linux" ];
  };
}
