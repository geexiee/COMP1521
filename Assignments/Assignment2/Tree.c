// Tree.h ... implementation of binary search tree ADT
// Written by John Shepherd, March 2013

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "Tree.h"
#include "myHeap.h"

typedef struct node *Link;

typedef struct node {
	Item value;
	Link left, right;
} Node;

// make a new node containing a value
static
Link newNode(int v)
{
	Link new = myMalloc(sizeof(Node));
	assert(new != NULL);
	new->value = v;
	new->left = new->right = NULL;
	return new;
}

// create a new empty Tree
Tree newTree()
{
	return NULL;
}

// free memory associated with Tree
void dropTree(Tree t)
{
	if (t == NULL) return;
	dropTree(t->left);
	dropTree(t->right);
	myFree(t);
}

// display a Tree (sideways)
void showTree(Tree t)
{
	void doShowTree(Tree);
	doShowTree(t);
}

// compute depth of Tree
int depth(Tree t)
{
	if (t == NULL)
		return 0;
	else {
		int ld = depth(t->left);
		int rd = depth(t->right);
		return 1 + ((ld > rd)?ld:rd);
	}
}

// count #nodes in Tree
int nnodes(Tree t)
{
	if (t == NULL) return 0;
	return 1 + nnodes(t->left) + nnodes(t->right);
}

// insert a new value into a Tree
Tree insert(Tree t, Item it)
{
	if (t == NULL) return newNode(it);
	int diff = cmp(key(it),key(t->value));
	if (diff == 0)
		t->value = it;
	else if (diff < 0)
		t->left = insert(t->left, it);
	else if (diff > 0)
		t->right = insert(t->right, it);
	return t;
}

Tree insertAtRoot(Tree t, Item it)
{ 
   if (t == NULL) return newNode(it);
   int diff = cmp(key(it), key(t->value));
   if (diff == 0)
      t->value = it;
   else if (diff < 0) {
      t->left = insertAtRoot(t->left, it);
      //printf("rotateR(%d)\n",t->value);
      t = rotateR(t);
   }
   else if (diff > 0) {
      t->right = insertAtRoot(t->right, it);
      //printf("rotateL(%d)\n",t->value);
      t = rotateL(t);
   }
   return t;
}

Tree insertRandom(Tree t, Item it)
{
   if (t == NULL) return newNode(it);
   int chance = rand() % 3;
   if (chance == 0)
      t = insertAtRoot(t, it);
   else
      t = insert(t, it);
   return t;
}

// check whether a value is in a Tree
int find(Tree t, Key k)
{
	if (t == NULL) return 0;
	int res, diff = cmp(k,t->value);
	if (diff < 0)
		res = find(t->left, k);
	else if (diff > 0)
		res = find(t->right, k);
	else // (diff == 0)
		res = 1;
	return res;
}

// delete a value from a Tree
Tree delete(Tree t, Key k)
{
	Tree deleteRoot(Tree);

	if (t == NULL)
		return NULL;
	int diff = cmp(k,t->value);
	if (diff == 0)
		t = deleteRoot(t);
	else if (diff < 0)
		t->left = delete(t->left, k);
	else if (diff > 0)
		t->right = delete(t->right, k);
	return t;
}

// delete root of tree
Tree deleteRoot(Tree t)
{
	Link newRoot;
	// if no subtrees, tree empty after delete
	if (t->left == NULL && t->right == NULL) {
		myFree(t);
		return NULL;
	}
	// if only right subtree, make it the new root
	else if (t->left == NULL && t->right != NULL) {
		newRoot = t->right;
		myFree(t);
		return newRoot;
	}
	// if only left subtree, make it the new root
	else if (t->left != NULL && t->right == NULL) {
		newRoot = t->left;
		myFree(t);
		return newRoot;
	}
	else {  // (t->left != NULL && t->right != NULL)
		// so has two subtrees
		// - find inorder successor (grab value)
		// - delete inorder successor node
		// - move its value to root
		Link succ = t->right; // not null!
		while (succ->left != NULL) {
			succ = succ->left;
		}
		int succVal = succ->value;
		t = delete(t,succVal);
		t->value = succVal;
		return t;
	}
}

Link rotateR(Link n1)
{
   if (n1 == NULL) return n1;
   Link n2 = n1->left;
   if (n2 == NULL) return n1;
   n1->left = n2->right;
   n2->right = n1;
   return n2;
}

Link rotateL(Link n2)
{
   if (n2 == NULL) return n2;
   Link n1 = n2->right;
   if (n1 == NULL) return n2;
   n2->right = n1->left;
   n1->left = n2;
   return n1;
}

Tree partition(Tree t, int i)
{
   if (t == NULL) return NULL;
   assert(0 <= i && i < nnodes(t));
   int n = nnodes(t->left);
   if (i < n) {
      t->left = partition(t->left, i);
      t = rotateR(t);
   }
   if (i > n) {
      t->right = partition(t->right, i-n-1);
      t = rotateL(t);
   }
   return t;
}

Item *get_ith(Tree t, int i)
{
   if (t == NULL) return NULL;
   assert(0 <= i && i < nnodes(t));
   int n = nnodes(t->left); // #nodes to left of root
   if (i < n) return get_ith(t->left, i);
   if (i > n) return get_ith(t->right, i-n-1);
   return &(t->value);
}

Tree rebalance(Tree t)
{
    if (t == NULL) return NULL;
    // nnodes(t) = 1 + nnodes(L) + nnodes(R)
    if (nnodes(t) < 2) return t;
    // put node with median key at root
    t = partition(t, nnodes(t)/2);
    // then rebalance each subtree
    t->left = rebalance(t->left);
    t->right = rebalance(t->right);
    return t;
}




// ASCII tree printer
// Courtesy: ponnada
// Via: http://www.openasthra.com/c-tidbits/printing-binary-trees-in-ascii/

// data structures
typedef struct asciinode_struct asciinode;
struct asciinode_struct
{
	asciinode * left, * right;
	//length of the edge from this node to its children
	int edge_length;
	int height;
	int lablen;
	//-1=I am left, 0=I am root, 1=I am right
	int parent_dir;
	//max supported unit32 in dec, 10 digits max
	char label[11];
};

// functions
void print_level(asciinode *node, int x, int level);
void compute_edge_lengths(asciinode *node);
void compute_lprofile(asciinode *node, int x, int y);
void compute_rprofile(asciinode *node, int x, int y);
asciinode *build_ascii_tree(Tree t);
void free_ascii_tree(asciinode *node);

#define MAX_HEIGHT 1000
int lprofile[MAX_HEIGHT];
int rprofile[MAX_HEIGHT];
#define INFINITY (1<<20)

#define MIN(X,Y)  (((X) < (Y)) ? (X) : (Y))
#define MAX(X,Y)  (((X) > (Y)) ? (X) : (Y))

int gap = 3;  // gap between left and right nodes

//used for printing next node in the same level, 
//this is the x coordinate of the next char printed
int print_next;    

//prints ascii tree for given Tree structure
void doShowTree(Tree t)
{
	asciinode *proot;
	int xmin, i;
	if (t == NULL) return;
	proot = build_ascii_tree(t);
	compute_edge_lengths(proot);
	for (i = 0; i < proot->height && i < MAX_HEIGHT; i++)
		lprofile[i] = INFINITY;
	compute_lprofile(proot, 0, 0);
	xmin = 0;
	for (i = 0; i < proot->height && i < MAX_HEIGHT; i++)
		xmin = MIN(xmin, lprofile[i]);
	for (i = 0; i < proot->height; i++) {
		print_next = 0;
		print_level(proot, -xmin, i);
		printf("\n");
	}
	if (proot->height >= MAX_HEIGHT) {
		printf("(Tree is taller than %d; may be drawn incorrectly.)\n",
			MAX_HEIGHT);
	}
	free_ascii_tree(proot);
}

//This function prints the given level of the given tree, assuming
//that the node has the given x cordinate.
void print_level(asciinode *node, int x, int level)
{
	int i, isleft;
	if (node == NULL) return;
	isleft = (node->parent_dir == -1);
	if (level == 0)
	{
		for (i=0; i<(x-print_next-((node->lablen-isleft)/2)); i++)
			printf(" ");
		print_next += i;
		printf("%s", node->label);
		print_next += node->lablen;
	}
	else if (node->edge_length >= level)
	{
		if (node->left != NULL)
		{
		  for (i=0; i<(x-print_next-(level)); i++)
		  {
		    printf(" ");
		  }
		  print_next += i;
		  printf("/");
		  print_next++;
		}
		if (node->right != NULL)
		{
		  for (i=0; i<(x-print_next+(level)); i++)
		  {
		    printf(" ");
		  }
		  print_next += i;
		  printf("\\");
		  print_next++;
		}
	}
	else
	{
		print_level(node->left,
			    x-node->edge_length-1,
			    level-node->edge_length-1);
		print_level(node->right,
			    x+node->edge_length+1,
			    level-node->edge_length-1);
	}
}


//This function fills in the edge_length and
//height fields of the specified tree
void compute_edge_lengths(asciinode *node)
{
	int h, hmin, i, delta;
	if (node == NULL) return;
	compute_edge_lengths(node->left);
	compute_edge_lengths(node->right);

	/* first fill in the edge_length of node */
	if (node->right == NULL && node->left == NULL)
		node->edge_length = 0;
	else
	{
		if (node->left == NULL)
			hmin = 0;
		else {
			for (i = 0; i < node->left->height && i < MAX_HEIGHT; i++)
				rprofile[i] = -INFINITY;
			compute_rprofile(node->left, 0, 0);
			hmin = node->left->height;
		}
		if (node->right == NULL)
			hmin = 0;
		else {
			for (i=0; i<node->right->height && i < MAX_HEIGHT; i++)
		    		lprofile[i] = INFINITY;
			compute_lprofile(node->right, 0, 0);
			hmin = MIN(node->right->height, hmin);
		}
		delta = 4;
		for (i=0; i<hmin; i++) {
			int w = gap+1+rprofile[i]-lprofile[i];
			delta = (delta > w) ? delta : w;
		}

		//If the node has two children of height 1, then we allow the
		//two leaves to be within 1, instead of 2
		if (((node->left != NULL && node->left->height == 1) ||
		      (node->right != NULL && node->right->height == 1))
				&& delta > 4)
			delta--;
		node->edge_length = ((delta+1)/2) - 1;
	}

	//now fill in the height of node
	h = 1;
	if (node->left != NULL)
		h = MAX(node->left->height + node->edge_length + 1, h);
	if (node->right != NULL)
		h = MAX(node->right->height + node->edge_length + 1, h);
	node->height = h;
}

asciinode *build_ascii_tree_recursive(Tree t)
{
	asciinode * node;

	if (t == NULL) return NULL;
	node = myMalloc(sizeof(asciinode));
	node->left = build_ascii_tree_recursive(t->left);
	node->right = build_ascii_tree_recursive(t->right);
	if (node->left != NULL) node->left->parent_dir = -1;
	if (node->right != NULL) node->right->parent_dir = 1;
	sprintf(node->label, "%d", t->value);
	node->lablen = strlen(node->label);;
	return node;
}


//Copy the tree into the ascii node structre
asciinode *build_ascii_tree(Tree t)
{
	asciinode *node;
	if (t == NULL) return NULL;
	node = build_ascii_tree_recursive(t);
	node->parent_dir = 0;
	return node;
}

//Free all the nodes of the given tree
void free_ascii_tree(asciinode *node)
{
	if (node == NULL) return;
	free_ascii_tree(node->left);
	free_ascii_tree(node->right);
	myFree(node);
}

//The following function fills in the lprofile array for the given tree.
//It assumes that the center of the label of the root of this tree
//is located at a position (x,y).  It assumes that the edge_length
//fields have been computed for this tree.
void compute_lprofile(asciinode *node, int x, int y)
{
	int i, isleft;
	if (node == NULL) return;
	isleft = (node->parent_dir == -1);
	lprofile[y] = MIN(lprofile[y], x-((node->lablen-isleft)/2));
	if (node->left != NULL) {
		for (i=1; i <= node->edge_length && y+i < MAX_HEIGHT; i++)
			lprofile[y+i] = MIN(lprofile[y+i], x-i);
	}
	compute_lprofile(node->left, x-node->edge_length-1, y+node->edge_length+1);
	compute_lprofile(node->right, x+node->edge_length+1, y+node->edge_length+1);
}

void compute_rprofile(asciinode *node, int x, int y)
{
	int i, notleft;
	if (node == NULL) return;
	notleft = (node->parent_dir != -1);
	rprofile[y] = MAX(rprofile[y], x+((node->lablen-notleft)/2));
	if (node->right != NULL) {
		for (i=1; i <= node->edge_length && y+i < MAX_HEIGHT; i++)
	  		rprofile[y+i] = MAX(rprofile[y+i], x+i);
	}
	compute_rprofile(node->left, x-node->edge_length-1, y+node->edge_length+1);
	compute_rprofile(node->right, x+node->edge_length+1, y+node->edge_length+1);
}
