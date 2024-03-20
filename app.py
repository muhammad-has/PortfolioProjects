import random
import csv 

def get_user_choice():
    msg = '''
    1- Add New Topic
    2- Suggest topic to Practice
    3- Exite
    Please Enter What You Want to do: '''
    return input(msg)


def add_new_topic():
    print(f'the current topics are: {read_topics()}')
    topic_list = input("Enter the topics separated by comma: ").split(', ')
    with open('topics.csv', 'a') as file:
        writer = csv.writer(file)
        writer.writerow(topic_list)

def read_topics():
    topics = []
    with open('topics.csv', 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            topics.extend(row)
    return topics

def suggest_rand_topic():
    topics = read_topics()
    return random.choice(topics) if topics else 'No Topics availble'



def main():
    menue_options = {
        '1': lambda: add_new_topic(),
        '2': lambda: print(f'Today\'s Topic -> "{suggest_rand_topic()}"'),
        '3': lambda: print('Exiting...'),
    }

    while True:
        to_do = get_user_choice()
        
        if to_do in menue_options:
            menue_options[to_do]()
            if to_do == '3':
                break
        else:
            print('You only can write values 1, 2 or 3') 


if __name__ == "__main__":
    main()