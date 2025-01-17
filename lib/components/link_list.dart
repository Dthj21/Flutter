import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'create_link.dart';
import 'login.dart';

const String FEED_QUERY = '''
  query {
    links {
      id
      nombre
      descripcion
      precio
      url
      postedBy {
        username
      }
      votes {
        id
      }
    }
  }
''';

const String VOTE_MUTATION = '''
  mutation VoteMutation(\$linkId: Int!) {
    createVote(linkId: \$linkId) {
      link {
        id
        votes {
          id
        }
      }
    }
  }
''';

class LinkListScreen extends StatefulWidget {
  @override
  _LinkListScreenState createState() => _LinkListScreenState();
}

class _LinkListScreenState extends State<LinkListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker-Fake'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateLinkScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(FEED_QUERY),
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List links = result.data?['links'] ?? [];

          if (links.isEmpty) {
            return Center(child: Text('No links found'));
          }

          return ListView.builder(
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];

              if (link == null) {
                return ListTile(
                  title: Text('Link is null'),
                );
              }

              final postedBy = link['postedBy'];
              final username = postedBy != null ? postedBy['username'] : 'Unknown';

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Image.network(
                          link['url'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link['nombre'] ?? 'No Title',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Descripción: ${link['descripcion'] ?? 'No description'}'),
                            Text('Precio: ${link['precio'] ?? 'No price'}'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Posted by: $username'),
                                Mutation(
                                  options: MutationOptions(
                                    document: gql(VOTE_MUTATION),
                                    onCompleted: (dynamic resultData) {
                                      refetch?.call();
                                    },
                                  ),
                                  builder: (RunMutation runMutation, QueryResult? result) {
                                    int votesCount = link['votes']?.length ?? 0;
                                    return Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.thumb_up, size: 16),
                                          onPressed: () {
                                            runMutation({'linkId': link['id']});
                                            setState(() {
                                              votesCount += 1;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text('$votesCount'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
