require 'spec_helper'

describe 'downloads routing' do
  let(:noid) { '1a2b3c' }
  let(:thumbnail) { 'thumb' }

  it "routes GET /downloads/:id" do
    expect(
      get: "/downloads/#{noid}"
    ).to(
      route_to(
        controller: "downloads",
        action: "show",
        id: noid
      )
    )
  end

  it "routes GET /downloads/:id/:datastream_id" do
    expect(
        get: "/downloads/#{noid}/#{thumbnail}"
    ).to(
        route_to(
            controller: "downloads",
            action: "show",
            id: noid,
            datastream_id: thumbnail
        )
    )
  end

  it 'test named route to call action with  id and datastream' do
    expect(download_path(noid, thumbnail)).to eq("/downloads/#{noid}/#{thumbnail}")
    expect(
       get: download_path(noid, thumbnail)
    ).to(
        route_to(
            controller: "downloads",
            action: "show",
            id: noid,
            datastream_id: thumbnail
        )
    )
  end

  it 'test named route with explicit param to call action with correct id and datastream' do
    expect(download_path(noid, datastream_id: thumbnail)).to eq("/downloads/#{noid}/#{thumbnail}")
    expect(
       get: download_path(noid, thumbnail)
    ).to(
        route_to(
            controller: "downloads",
            action: "show",
            id: noid,
            datastream_id: thumbnail
        )
    )
  end
end
