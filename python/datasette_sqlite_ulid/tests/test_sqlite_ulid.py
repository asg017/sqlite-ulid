from datasette.app import Datasette
import pytest


@pytest.mark.asyncio
async def test_plugin_is_installed():
    datasette = Datasette(memory=True)
    response = await datasette.client.get("/-/plugins.json")
    assert response.status_code == 200
    installed_plugins = {p["name"] for p in response.json()}
    assert "datasette-sqlite-ulid" in installed_plugins

@pytest.mark.asyncio
async def test_sqlite_ulid_functions():
    datasette = Datasette(memory=True)
    response = await datasette.client.get("/_memory.json?sql=select+ulid_version(),ulid()")
    assert response.status_code == 200
    ulid_version, ulid = response.json()["rows"][0]
    assert ulid_version[0] == "v"
    assert len(ulid) == 26