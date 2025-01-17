class Application < ApplicationRecord
  has_many :application_pets
  has_many :pets, through: :application_pets
  validates :name, presence: true
  validates :street_address, presence: true
  validates  :city, presence: true
  validates  :state, presence: true
  validates  :zip, presence: true

  def full_address
    "#{street_address}, #{city}, #{state}, #{zip}"
  end

  def add_pet_to_application(pet)
    pets << pet
  end

  def check_status
    application_pets = ApplicationPet.where(application_id: self.id)

    if application_pets.all? { |application_pet| application_pet.state == "Approved"}
      self.update(status: "Approved")
      make_pets_not_adoptable
    elsif application_pets.any? { |application_pet| application_pet.state == "Rejected"}
      self.update(status: "Rejected")
    end
  end

  def lookup_state(pet_id)
    ApplicationPet.where(application_id: self.id, pet_id: pet_id).pluck(:state)[0]
  end

  private
      def make_pets_not_adoptable
        pets.each { |pet| pet.update(adoptable: false)}
      end
end
