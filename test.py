from file import hello_func


def test_hello():
    assert hello_func() == "hello"
    print("test passed")
    
    
test_hello()