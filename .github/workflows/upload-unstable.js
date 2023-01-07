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
    tag: "unstable",
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
    uploadReleaseAsset("sqlite-xsv-ubuntu/ulid0.so", "xsv0.so"),
    uploadReleaseAsset("sqlite-xsv-macos/ulid0.dylib", "xsv0.dylib"),
    uploadReleaseAsset("sqlite-xsv-windows/ulid0.dll", "xsv0.dll"),
  ]);

  return;
};
