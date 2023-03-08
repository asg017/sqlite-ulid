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
  console.log("release id: ", release.data.id);
  const release_id = release.data.id;

  const compiled_extensions = [
    {
      path: "sqlite-ulid-macos-arm/ulid0.dylib",
      name: "deno-darwin-aarch64.ulid0.dylib",
    },
    {
      path: "sqlite-ulid-macos/ulid0.dylib",
      name: "deno-darwin-x86_64.ulid0.dylib",
    },
    {
      path: "sqlite-ulid-ubuntu/ulid0.so",
      name: "deno-linux-x86_64.ulid0.so",
    },
    {
      path: "sqlite-ulid-windows/ulid0.dll",
      name: "deno-windows-x86_64.ulid0.dll",
    },
  ];
  await Promise.all(
    compiled_extensions.map(async ({ name, path }) => {
      return github.rest.repos.uploadReleaseAsset({
        owner,
        repo,
        release_id,
        name,
        data: await fs.readFile(path),
      });
    })
  );
};
