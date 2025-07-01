import unittest
from src.run import create_app
from src.database import db
from src.model import Submission
from src.config import TestConfig
from datetime import datetime, timedelta
class DatabaseTestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app(config_class=TestConfig)
        self.client = self.app.test_client()
        self.ctx = self.app.app_context()
        self.ctx.push()
        db.create_all()

    def tearDown(self):
        db.session.remove()
        db.drop_all()
        self.ctx.pop()

    def test_create_submission_model(self):
        submission = Submission(
            full_name="Test DB",
            email="db@example.com",
            phone_number="1234567890",
            age=30,
            address="DB street",
            preferred_contact="Email"
        )
        db.session.add(submission)
        db.session.commit()

        fetched = Submission.query.first()
        self.assertEqual(fetched.full_name, "Test DB")
        self.assertEqual(fetched.email, "db@example.com")

    def test_update_submission_model(self):
        submission = Submission(
            full_name="Before Update",
            email="update@example.com",
            phone_number="9876543210",
            age=25,
            address="Update Rd",
            preferred_contact="Phone"
        )
        db.session.add(submission)
        db.session.commit()

        submission.full_name = "After Update"
        db.session.commit()

        updated = Submission.query.first()
        self.assertEqual(updated.full_name, "After Update")

    def test_delete_submission_model(self):
        submission = Submission(
            full_name="To Delete",
            email="delete@example.com",
            phone_number="4444444444",
            age=40,
            address="Delete Ln",
            preferred_contact="Both"
        )
        db.session.add(submission)
        db.session.commit()

        db.session.delete(submission)
        db.session.commit()

        self.assertEqual(Submission.query.count(), 0)

    def test_submission_ordering(self):
        # Add 2 submissions
        now = datetime.utcnow()
   
        first_submission =  Submission(full_name="First", email="a@example.com", phone_number="1", age=20, address="", preferred_contact="Email",created_at=now - timedelta(seconds=1))
        second_submission = Submission(full_name="Second", email="b@example.com", phone_number="2", age=21, address="", preferred_contact="Email",created_at=now)

        db.session.add_all([first_submission, second_submission])
        db.session.commit()

        ordered = Submission.query.order_by(Submission.created_at.desc()).all()
        self.assertEqual(ordered[0].full_name, "Second")

if __name__ == '__main__':
    unittest.main()
