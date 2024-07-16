def print_hello():
    return "hello"


def test_hello():
    assert print_hello() == "hello"
    print("test passed")
    
    
test_hello()