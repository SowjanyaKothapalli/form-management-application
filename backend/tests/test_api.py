import unittest
from src.run import create_app
from src.database import db
from src.model import Submission
from src.config import TestConfig

class APITestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app(config_class=TestConfig)
        self.app.config.from_object(TestConfig) 
        self.client = self.app.test_client()

        with self.app.app_context():
            db.create_all()

    def tearDown(self):
        with self.app.app_context():
            db.drop_all()

    def test_health_check(self):
        res = self.client.get('/api/health')
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.get_json()["status"], "server is running")

    def test_create_submission(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "Test User",
            "email": "test@example.com",
            "phone_number": "1234567890",
            "age": 30,
            "address": "Test City",
            "preferred_contact": "Email"
        })
        self.assertEqual(res.status_code, 201)
        self.assertIn(b'Test User', res.data)

    def test_get_all_submissions(self):
        self.test_create_submission()
        res = self.client.get('/api/submissions')
        self.assertEqual(res.status_code, 200)
        self.assertIn(b'test@example.com', res.data)

    def test_get_submission_by_id(self):
        post_res = self.client.post('/api/submissions', json={
            "full_name": "John",
            "email": "john@example.com",
            "phone_number": "1111111111",
            "age": 40,
            "address": "Somewhere",
            "preferred_contact": "Phone"
        })
        submission_id = post_res.get_json()['id']
        res = self.client.get(f'/api/submissions/{submission_id}')
        self.assertEqual(res.status_code, 200)
        self.assertIn(b'John', res.data)

    def test_update_submission(self):
        post_res = self.client.post('/api/submissions', json={
            "full_name": "Old Name",
            "email": "old@example.com",
            "phone_number": "9999999999",
            "age": 29,
            "address": "Old Address",
            "preferred_contact": "Email"
        })
        submission_id = post_res.get_json()['id']
        update_res = self.client.put(f'/api/submissions/{submission_id}', json={
            "full_name": "Updated Name",
            "email": "old@example.com",
            "phone_number": "9999999999",
            "age": 30,
            "address": "New Address",
            "preferred_contact": "Both"
        })
        self.assertEqual(update_res.status_code, 200)
        self.assertIn(b'Updated Name', update_res.data)

    def test_missing_field_returns_400(self):
        res = self.client.post('/api/submissions', json={
            # Missing "email"
            "full_name": "No Email",
            "phone_number": "1234567890",
            "age": 25,
            "address": "City",
            "preferred_contact": "Email"
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'email is missing', res.data.lower())

    def test_invalid_age_returns_400(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "Bad Age",
            "email": "bad@example.com",
            "phone_number": "1234567890",
            "age": -1,
            "address": "City",
            "preferred_contact": "Email"
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'invalid age', res.data.lower())

    def test_invalid_email_format_returns_400(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "Bad Email",
            "email": "not-an-email",
            "phone_number": "1234567890",
            "age": 30,
            "address": "Test",
            "preferred_contact": "Phone"
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'invalid email', res.data.lower())

    def test_get_nonexistent_submission_returns_404(self):
        res = self.client.get('/api/submissions/99999')
        self.assertEqual(res.status_code, 404)

    def test_delete_nonexistent_submission_returns_404(self):
        res = self.client.delete('/api/submissions/99999')
        self.assertEqual(res.status_code, 404)       

    def test_missing_required_fields(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "",  # required
            "email": "",      # required
            "phone_number": "",
            "age": "",
            "preferred_contact": ""
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'missing', res.data.lower())  
    def test_invalid_age(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "Test",
            "email": "test@example.com",
            "phone_number": "1234567890",
            "age": 12,  # invalid
            "address": "Nowhere",
            "preferred_contact": "Email"
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'invalid age', res.data.lower())   
    def test_invalid_email_format(self):
        res = self.client.post('/api/submissions', json={
            "full_name": "Test",
            "email": "not-an-email",
            "phone_number": "1234567890",
            "age": 25,
            "address": "Anywhere",
            "preferred_contact": "Phone"
        })
        self.assertEqual(res.status_code, 400)
        self.assertIn(b'invalid email', res.data.lower())               
    def test_delete_submission(self):
        post_res = self.client.post('/api/submissions', json={
            "full_name": "Delete Me",
            "email": "delete@example.com",
            "phone_number": "4444444444",
            "age": 33,
            "address": "To be deleted",
            "preferred_contact": "Phone"
        })
        submission_id = post_res.get_json()['id']
        delete_res = self.client.delete(f'/api/submissions/{submission_id}')
        self.assertEqual(delete_res.status_code, 204)

        # Confirm it's gone
        get_res = self.client.get(f'/api/submissions/{submission_id}')
        self.assertEqual(get_res.status_code, 404)

if __name__ == '__main__':
    unittest.main()
