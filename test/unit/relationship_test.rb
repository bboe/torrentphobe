require 'test/test_helper'

class RelationshipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "delete relationships" do
    bob_to_alice = relationships(:bob_to_alice)
    assert_difference("Relationship.count", -1) do
      bob_to_alice.delete
      bob_to_alice.save
    end
    assert !Relationship.exists?(bob_to_alice.id)
    u = Relationship.find_by_sql("select * from relationships where id = " + bob_to_alice.id.to_s)[0]
    assert_equal bob_to_alice, u        
  end 

end
