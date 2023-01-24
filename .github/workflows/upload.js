const fs = require("fs").promises;

module.exports = async ({ github, context }) => {
  const {
    repo: { owner, repo },
    sha,
  } = context;
  console.log(process.env.GITHUB_REF);
  const release = await github.rest.repos.getReleaseByTag({
    owner,
    repo,
    tag: process.env.GITHUB_REF.replace("refs/tags/", ""),
  });

  const release_id = release.data.id;
  async function uploadReleaseAsset(path, name) {
    console.log("Uploading", name, "at", path);

    return github.rest.repos.uploadReleaseAsset({
      owner,
      repo,
      release_id,
      name,
      data: await fs.readFile(path),
    });
  }
  await Promise.all([
    uploadReleaseAsset("sqlite-ulid-ubuntu/ulid0.so", "linux-x86_64-ulid0.so"),
    uploadReleaseAsset(
      "sqlite-ulid-macos/ulid0.dylib",
      "macos-x86_64-ulid0.dylib"
    ),
    uploadReleaseAsset(
      "sqlite-ulid-macos-arm/ulid0.dylib",
      "macos-arm-ulid0.dylib"
    ),
    uploadReleaseAsset(
      "sqlite-ulid-windows/ulid0.dll",
      "windows-x86_64-ulid0.dll"
    ),
  ]);

  return;
};
