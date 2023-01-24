const fs = require("fs").promises;
const crypto = require("crypto");
const archiver = require("archiver");
const stream = require("stream");

function targz(files) {
  return new Promise((resolve, reject) => {
    console.log("targz files: ", files[0].name, files[0]);
    const output = new stream.PassThrough();
    const archive = archiver("tar", {
      gzip: true,
      gzipOptions: {
        level: 1,
      },
    });

    /**/

    archive.pipe(output);
    for (const file of files) {
      archive.append(file.data, { name: file.name });
    }

    archive.on("error", reject);
    output.on("error", reject);
    output.on("close", () => {
      resolve(output.read());
      console.log("targz close");
    });

    archive.on("finish", () => {
      console.log("archive finish");
      resolve(output.read());
    });
    archive.finalize().then(() => console.log("finalize?"));
  });
}

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
      name: "ulid0.so",
      path: "sqlite-ulid-ubuntu/ulid0.so",
      asset_name: "sqlite-ulid-vTODO-ubuntu-x86_64.tar.gz",
    },
    /*{
      name: "ulid0.dylib",
      path: "sqlite-ulid-macos/ulid0.dylib",
    },
    {
      name: "ulid0.dylib",
      path: "sqlite-ulid-macos-arm/ulid0.dylib",
    },
    {
      name: "ulid0.dll",
      path: "sqlite-ulid-windows/ulid0.dll",
    },*/
  ];
  console.log(compiled_extensions);

  let extension_assets = await Promise.all(
    compiled_extensions.map(async (d) => {
      const extensionContents = await fs.readFile(d.path);
      const ext_sha256 = crypto
        .createHash("sha256")
        .update(extensionContents)
        .digest("hex");
      console.log("ext_sha256", ext_sha256);
      const tar = await targz([{ name: d.name, data: extensionContents }]);

      const tar_md5 = crypto.createHash("md5").update(tar).digest("base64");
      const tar_sha256 = crypto.createHash("sha256").update(tar).digest("hex");
      console.log("tar_md5", tar_md5);
      console.log("tar_sha256", tar_sha256);

      return {
        ext_sha256,
        tar_md5,
        tar_sha256,
        tar,
        asset_name: d.asset_name,
      };
    })
  );
  console.log("assets length: ", extension_assets.length);
  let checksum = {
    extensions: Object.fromEntries(
      extension_assets.map((d) => [
        d.asset_name,
        {
          asset_sha265: d.tar_sha256,
          asset_md5: d.tar_md5,
          extension_sha256: d.ext_sha256,
        },
      ])
    ),
  };
  console.log("checksum", checksum);

  await github.rest.repos.uploadReleaseAsset({
    owner,
    repo,
    release_id,
    name: "spm.json",
    data: JSON.stringify(checksum),
  });

  await Promise.all(
    extension_assets.map(async (d) => {
      console.log("uploading ", d.asset_name);
      await github.rest.repos.uploadReleaseAsset({
        owner,
        repo,
        release_id,
        name: d.asset_name,
        data: d.tar,
      });
    })
  );
  return;
};
