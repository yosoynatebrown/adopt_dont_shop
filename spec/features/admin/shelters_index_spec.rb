require 'rails_helper'

RSpec.describe 'the shelters index' do
  before(:each) do
    @shelter_2 = Shelter.create(name: 'RGV animal shelter', city: 'Harlingen, TX', foster_program: false, rank: 5)
    @shelter_1 = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    @shelter_3 = Shelter.create(name: 'Fancy pets of Colorado', city: 'Denver, CO', foster_program: true, rank: 10)
    @pirate = @shelter_1.pets.create(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: true)
    @clawdia = @shelter_1.pets.create(name: 'Clawdia', breed: 'shorthair', age: 3, adoptable: true)
    @teddy = @shelter_2.pets.create(name: 'Teddy', breed: 'terrier', age: 12, adoptable: true)
    @lucille = @shelter_3.pets.create(name: 'Lucille Bald', breed: 'sphynx', age: 8, adoptable: true)
  end
  it 'lists all the shelter names' do
    visit "admin/shelters"

    expect(page).to have_content(@shelter_1.name)
    expect(page).to have_content(@shelter_2.name)
    expect(page).to have_content(@shelter_3.name)
  end

  it 'lists the shelters in reverse alphabetical order' do
    visit "admin/shelters"

    earliest = find("#shelter-#{@shelter_2.id}")
    mid = find("#shelter-#{@shelter_3.id}")
    latest = find("#shelter-#{@shelter_1.id}")

    expect(earliest).to appear_before(mid)
    expect(mid).to appear_before(latest)
  end

  it 'has a section which lists shelters with pending applications in alphabetical order' do
    application = Application.create!(
                                      name: "Nate Brown",
                            street_address: "2000 35th Avenue",
                                      city: "Denver",
                                     state: "CO",
                                       zip: "90210",
                                    status: "Pending"
                                        )

    application.add_pet_to_application(@lucille)
    application.add_pet_to_application(@teddy)
  
    visit "admin/shelters"

    within '#pending-shelters' do
      expect(page).to have_content("Shelters with Pending Applications")
      expect(page).to have_content(@shelter_3.name)
      expect(page).to have_content(@shelter_2.name)
      expect(page).to_not have_content(@shelter_1.name)

      expect(page.text.index(@shelter_2.name)).to be > page.text.index(@shelter_3.name)
    end
  end

  it 'has working links to admin shelter show page' do
    visit "admin/shelters"

    click_link "#{@shelter_1.name}"

    expect(page).to have_current_path("/admin/shelters/#{@shelter_1.id}")
  end
end
